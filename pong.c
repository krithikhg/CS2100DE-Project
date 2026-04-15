#define LED_ADDR 0x2400
#define DIP_ADDR 0x2404
#define BTN_ADDR 0x2408
#define SEG_ADDR 0x2418

#define BLANK 0x0
#define BALL  0x1

int main() {
    volatile int* led_ptr = (volatile int*)LED_ADDR;
    volatile int* dip_ptr = (volatile int*)DIP_ADDR;
    volatile int* seg_ptr = (volatile int*)SEG_ADDR;

    int ball_pos = 3;
    int direction = 1;
    int speed = 1000000;
    int running = 1;

    // Read initial switch state as baseline
    int prev_sw = *dip_ptr;

    while (1) {
        // Build display: BALL nibble at ball_pos, BLANK elsewhere
        int seg_data = 0;
        for (int i = 0; i < 8; i++) {
            if (i == ball_pos) {
                seg_data |= (BALL << ((7 - i) * 4));
            }
        }
        *seg_ptr = seg_data;

        // Delay loop
        for (volatile int d = 0; d < speed; d++) {}

        if (!running) continue;

        // Read switches and detect state changes (flips)
        int sw = *dip_ptr;
        int right_flipped = (sw ^ prev_sw) & 1;
        int left_flipped = (sw ^ prev_sw) & (1 << 15);
        prev_sw = sw;

        // Right player flipped
        if (right_flipped) {
            if (ball_pos == 7) {
                direction = -1;  // Valid flip at boundary — bounce
            } else {
                running = 0;
                *led_ptr = 0xFF00;  // Too early — left wins
                continue;
            }
        }

        // Left player flipped
        if (left_flipped) {
            if (ball_pos == 0) {
                direction = 1;  // Valid flip at boundary — bounce
            } else {
                running = 0;
                *led_ptr = 0x00FF;  // Too early — right wins
                continue;
            }
        }

        // Move ball
        ball_pos += direction;

        // Ball went past right boundary — right player too late
        if (ball_pos > 7) {
            ball_pos = 7;
            running = 0;
            *led_ptr = 0xFF00;  // Left wins
        }

        // Ball went past left boundary — left player too late
        if (ball_pos < 0) {
            ball_pos = 0;
            running = 0;
            *led_ptr = 0x00FF;  // Right wins
        }
    }
}
