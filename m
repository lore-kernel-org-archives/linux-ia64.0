From: William Taber <wtaber@rational.com>
Date: Tue, 16 Jan 2001 17:57:10 +0000
Subject: [Linux-ia64] Bug in mm/memory.c
Message-Id: <marc-linux-ia64-105590693005053@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have been trying to build an i386 kernel against the 2.4.0 release with
the ia64-010109 patch applied to it.  I am hoping to be able to use a
common set of kernel sources for both platforms.  I have found a number of
integration problems which have been fairly simple to fix, and I will 
submit a patch for those when and if I get something that will work.  In
the course of doing this, I have found an out and out bug in memory.c.
Not only does it break i386 kernel builds, it won't work as expected for
ia64 either.

The following code fragment is in mm/memory.c line 1151:

static inline int handle_pte_fault(struct mm_struct *mm,
        struct vm_area_struct * vma, unsigned long address,
        int access_type, pte_t * pte)
{
        int write_access = is_write_access(access_type);
        int exec_access = is_exec_access(access_type);


where is_write_access and is_exec_access are defined in asm-ia64:pgtable.h
to be:

static inline int
is_write_access (int access_type)
{
        return (access_type & 0x2);
}

static inline int
is_exec_access (int access_type)
{
        return (access_type & 0x4);
}


handle_pte_fault is called from handle_mm_fault and access_type is passed
straight through.

However, in the two cases handle_mm_fault is called in memory.c, what is
passed in is not a flag value, but a boolean.  Therefore these checks are
wrong.  For instance, the code in make_pages_present is:

int make_pages_present(unsigned long addr, unsigned long end)
{
        int write;
        struct mm_struct *mm = current->mm;
        struct vm_area_struct * vma;

        vma = find_vma(mm, addr);
        write = (vma->vm_flags & VM_WRITE) != 0;
        if (addr >= end)
                BUG();
        do {
                if (handle_mm_fault(mm, vma, addr, write) < 0)


from map_user_kiobuf, the flag is set as:
        int                     datain = (rw = READ);


Before you just go ahead and change the callers to pass in the flag values,
you might want to verify that the same flag values are being used in both
cases and that the bits in the flags mean what you want them to mean.  A
quick look at the header files hints to me that they might not.  For my
purposes, I am going to revert this code back to the default 2.4.0 behaviour
until this can be done right and done portably.

Will Taber

+---------------------------------------------------------------------+
| Will Taber                                                          |
| Software Engineer, CMBU                 E-mail  wtaber@rational.com |
| Rational Software Corporation           Phone:  781-676-2436        |
| 20 Maguire Road, Lexington, Mass. 02421                             |
+---------------------------------------------------------------------+



