From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 10 Mar 2003 17:00:51 +0000
Subject: Re: [Linux-ia64] get_scratch_regs in bk 2.4 unwind.c
Message-Id: <marc-linux-ia64-105590709806018@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806009@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806009@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 08 Mar 2003 14:57:11 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> UNW_DPRINT(3, "unwind.%s: sp 0x%lx pt 0x%lx\n", __FUNCTION__, info->sp, info->pt);

  Keith> __FUNCTION__ will always print get_scratch_regs which is of no use, we
  Keith> need the calling function.  My patch passed in the calling function
  Keith> name as a parameter.  Please revert to passing in the function name or
  Keith> make get_scratch_regs a #define so it gets the calling function name.
  Keith> Also I printed the new value of info->pt, it is useful when debugging
  Keith> bad unwind data.

We're not going to pass around arguments that are only used for
debugging.  If you want to, we could print __builtin_return_address(0)
along with the function name (or we could use the kernel symbol table
to print the symbolic name).

  Keith> unw_access_gr has

  Keith> /* access a scratch register */
  Keith> if (!info->pt) {
  Keith> UNW_DPRINT(0, "unwind.%s: no pt-regs; cannot access r%d\n",
  Keith> __FUNCTION__, regnum);
  Keith> return -1;
  Keith> }
  Keith> pt = get_scratch_regs(info);

  Keith> Why the test for !info->pt?  No other use of get_scratch_regs
  Keith> has that test, unw_access_[abf]r will continue with whatever
  Keith> data get_scratch_regs returns, using pt_regs on top of stack
  Keith> if info->pt is undefined.  The code is inconsistent.

I agree.  Looks like something went wrong during the merge.  I'll fix
that.

	--david

