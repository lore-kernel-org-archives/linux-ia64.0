From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 25 Sep 2003 04:34:55 +0000
Subject: Re: PATCH: Re: Inefficient ia64 system call implementation in glibc
Message-Id: <marc-linux-ia64-106446452203374@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106438485815490@msgid-missing>
In-Reply-To: <marc-linux-ia64-106438485815490@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 24, 2003 at 02:12:38PM -0700, Jim Wilson wrote:
> On Wed, 2003-09-24 at 11:56, H. J. Lu wrote:
> > I don't think it will be the problem. Compiler will do
> > 	addl outN = constant, r0
> > to pass a constant to the function, regardless what the type is. Am I
> > correct?
> 
> No.
> 
> The compiler will emit RTL like this
> 	(set (reg:SI outN) (const_int constant))
> which will translate to a
> 	addl outN = constant, r0
> instruction.
> 
> However, if you are optimizing, then all we are guaranteed is that a
> value equivalent to an SImode constant will end up in the register.  If
> you have something like
>   if (i = 0)
>      sub (0);
> and i has type int, and i happens to be already in the right register
> for the first argument to sub, then the compiler will optimize away the
> load of zero as redundant.  The if statement uses cmp4 which only looks
> at the low order 4 bytes of i, and hence any value could be in the upper
> 4 bytes.  This is OK per the ABI, which says that only the low 4 bytes
> of an integer argument are valid.
> 

My patch only applies to LOAD_ARGS_##nr in

#define INTERNAL_SYSCALL(name, err, nr, args...)                \
  ({                                                            \
    register long _r8 asm ("r8");                               \
    register long _r10 asm ("r10");                             \
    register long _r15 asm ("r15") = __NR_##name;               \
    long _retval;                                               \
    LOAD_ARGS_##nr (args);                                      \
    __asm __volatile (BREAK_INSN (__BREAK_SYSCALL)              \
                      : "=r" (_r8), "=r" (_r10), "=r" (_r15)    \
                        ASM_OUTARGS_##nr                        \
                      : "2" (_r15) ASM_ARGS_##nr                \
                      : "memory" ASM_CLOBBERS_##nr);            \
    _retval = _r8;                                              \
    err = _r10;                                                 \
    _retval; })

I don't think it is an issue here. The current one is

#define LOAD_ARGS_1(out0)                               \
  register long _out0 asm ("out0") = (long) (out0);     \
  LOAD_ARGS_0 ()

I don't believe it is any better than

#define LOAD_ARGS_1(out0)                                      \
  register __typeof ((out0) + 0) _out0 asm ("out0") = (out0);  \
 
as far as function prototype is concerned. If there is a mismatch,
long can have problems too.


H.J.
