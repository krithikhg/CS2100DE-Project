main:
	lui	sp, 2
	nop
	nop
	nop
	addi	sp, sp, 256
	nop
	nop
	nop
        addi    sp, sp, -16
        nop
        nop
        nop                         # Resolve sp RAW for sw
        sw      s0, 12(sp)
        sw      s1, 8(sp)
        sw      s2, 4(sp)
        li      s2, 0
        lui     t3, 2
        li      t6, 3
        li      a1, 1
        li      a2, -4
        lui     a0, 244
        lui     a6, 8
        lw      t2, 1028(t3)
        nop                         # a0 written by lui 2 instructions prior; 1 nop needed
        addi    t5, a0, 575
        addi    a4, a0, 576
        lui     a7, 16
        nop
        nop
        nop                         # Resolve a7 RAW for addi
        addi    a7, a7, -256
        li      t0, 7
        li      t1, 1
.LBB0_1:
        mv      t4, t2
.LBB0_2:
        li      a5, 0
        li      a3, 28
        mv      a0, t6
        nop
        nop
        nop                         # Resolve a0 RAW for snez in .LBB0_3
.LBB0_3:
        snez    s0, a0
        sll     s1, a1, a3
        addi    a3, a3, -4
        nop                         # s0 written by snez 2 instructions prior; 1 nop needed
        addi    s0, s0, -1
        nop
        nop
        nop                         # Resolve s0 RAW for and
        and     s0, s0, s1
        nop
        nop
        nop                         # Resolve s0 RAW for or
        or      a5, a5, s0
        addi    a0, a0, -1
        nop
        nop                         # Resolve a0 RAW for snez on loop back
        bne     a3, a2, .LBB0_3
        sw      a5, 1048(t3)
        sw      zero, 0(sp)
        nop
        nop
        nop                         # Resolve Store-to-Load memory hazard for 0(sp)
        lw      a0, 0(sp)
        nop
        nop
        nop                         # Resolve a0 RAW for blt
        blt     t5, a0, .LBB0_6
.LBB0_5:
        lw      a0, 0(sp)
        nop
        nop
        nop                         # Resolve a0 RAW for addi
        addi    a0, a0, 1
        nop
        nop
        nop                         # Resolve a0 RAW for sw
        sw      a0, 0(sp)
        nop
        nop
        nop                         # Resolve Store-to-Load memory hazard for 0(sp)
        lw      a0, 0(sp)
        nop
        nop
        nop                         # Resolve a0 RAW for blt
        blt     a0, a4, .LBB0_5
.LBB0_6:
        andi    a0, s2, 1
        li      s2, 1
        nop
        nop                         # a0 written by andi 1 instruction prior; 2 nops needed
        bnez    a0, .LBB0_2
        lw      t2, 1028(t3)
        nop
        nop
        nop                         # Resolve t2 RAW for xor
        xor     a0, t2, t4
        nop
        nop
        nop                         # Resolve a0 RAW for andi
        andi    a3, a0, 1
        and     a0, a0, a6          
        nop
        nop                         # a3 written by andi 1 instruction prior; 2 nops needed
        bnez    a3, .LBB0_11
        beqz    a0, .LBB0_13        
        bnez    t6, .LBB0_18
        li      t1, 1
        j       .LBB0_13
.LBB0_11:
        bne     t6, t0, .LBB0_15
        li      t1, -1
        bnez    a0, .LBB0_18
.LBB0_13:
        nop
        nop
        nop                         # Resolve t1 RAW from preceding branches
        add     t6, t6, t1
        li      a0, 7
        nop
        nop
        nop                         # Resolve a0 RAW for bge
        bge     a0, t6, .LBB0_16
        mv      a0, a7
        li      t6, 7
        j       .LBB0_19
.LBB0_15:
        mv      a0, a7
        j       .LBB0_19
.LBB0_16:
        li      s2, 0
        bgez    t6, .LBB0_1
        li      t6, 0
.LBB0_18:
        li      a0, 255
.LBB0_19:
        nop
        nop
        nop                         # Resolve a0 RAW prior to sw
        sw      a0, 1024(t3)
        li      s2, 1
        j       .LBB0_1