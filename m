From: chas williams <chas@cmf.nrl.navy.mil>
Date: Wed, 01 Aug 2001 11:43:58 +0000
Subject: Re: [Linux-ia64] still patching syscall into module
Message-Id: <marc-linux-ia64-105590693005977@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005967@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005967@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

i solved most of my patching a syscall to a module problem the following
way:

unsigned char ia64_syscall_stub[] {
        0x05, 0x00, 0x00, 0x00, 0x01, 0x00,   /* [MLX]     nop.m 0x0         */
        0x00, 0x00, 0x00, 0x00, 0x00, 0xe0,   /*           movl r15=0x0;;    */
        0x01, 0x00, 0x00, 0x60,               /*                             */
        0x0b, 0x80, 0x20, 0x1e, 0x18, 0x14,   /* [MMI]     ld8 r16=[r15],8;; */
        0x10, 0x00, 0x3c, 0x30, 0x20, 0xc0,   /*           ld8 gp=[r15]      */
        0x00, 0x09, 0x00, 0x07,               /*           mov b6=r16;;      */
        0x1d, 0x00, 0x00, 0x00, 0x01, 0x00,   /* [MFB]     nop.m 0x0         */
        0x00, 0x00, 0x00, 0x02, 0x00, 0x00,   /*           nop.f 0x0         */
        0x60, 0x00, 0x80, 0x00,               /*           br.few b6;;       */
        0x0c, 0x00, 0x00, 0x00, 0x01, 0x00,   /* [MFI]     nop.m 0x0         */
        0x00, 0x00, 0x00, 0x02, 0x00, 0x00,   /*           nop.f 0x0         */
        0x00, 0x00, 0x04, 0x00                /*           nop.i 0x0         */
};

void ia64_imm64_fixup(unsigned long v, void *code)
{
        unsigned long *bundle = (unsigned long *) code;

        unsigned long insn;
        unsigned long slot1;

        insn = ((v & 0x8000000000000000) >> 27) | ((v & 0x0000000000200000)) |
           ((v & 0x00000000001f0000) <<  6) | ((v & 0x000000000000ff80) << 20) |
           ((v & 0x000000000000007f) << 13);

        slot1 = (v & 0x7fffffffffc00000) >> 22;

        *bundle |= slot1 << 46;
        *(bundle+1) |= insn << 23;
        *(bundle+1) |= slot1 >> 18;
}

at module load time i use ia64_imm64_fixup to patch the initial movl 
in the stub.   its very similar to the way insmod works. i only have
one hurdle left.  after returning from the syscall in the module the gp
needs to be returned to the kernel's gp so that ia64_leave_kernel wont die. 
not sure how to do this since i am new to the itanium.  should i save the rp
in my assembly stub and set the rp to come back to my stub so i can
patch the gp again?  something like:

...
	movl r14=gp
	movl b6=r16
	movl r15=rp
	movl r16=<current ip> cur_iip?
	aadl r16,<skip next bundle>
	br.few b6
	movl gp=r14
	movl rp=r15
	br.few rp


