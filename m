From: Keith Owens <kaos@sgi.com>
Date: Sat, 08 Mar 2003 03:57:11 +0000
Subject: [Linux-ia64] get_scratch_regs in bk 2.4 unwind.c
Message-Id: <marc-linux-ia64-105590709806009@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The bk version of unwind.c has some changes from my patch which do not
look right.

static inline struct pt_regs *
get_scratch_regs (struct unw_frame_info *info)
{
	if (!info->pt) {
		/* This should not happen with valid unwind info.  */
		UNW_DPRINT(0, "unwind.%s: bad unwind info: resetting info->pt\n", __FUNCTION__);
		info->pt = info->sp - 16;
	}
	UNW_DPRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", __FUNCTION__, info->sp, info->pt);
	return info->pt;
}

__FUNCTION__ will always print get_scratch_regs which is of no use, we
need the calling function.  My patch passed in the calling function
name as a parameter.  Please revert to passing in the function name or
make get_scratch_regs a #define so it gets the calling function name.
Also I printed the new value of info->pt, it is useful when debugging
bad unwind data.

unw_access_gr has

			/* access a scratch register */
			if (!info->pt) {
				UNW_DPRINT(0, "unwind.%s: no pt-regs; cannot access r%d\n",
					   __FUNCTION__, regnum);
				return -1;
			}
			pt = get_scratch_regs(info);

Why the test for !info->pt?  No other use of get_scratch_regs has that
test, unw_access_[abf]r will continue with whatever data get_scratch_regs
returns, using pt_regs on top of stack if info->pt is undefined.  The
code is inconsistent.


