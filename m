From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Nov 2003 01:34:56 +0000
Subject: Re: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-106989692626609@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106989195923088@msgid-missing>
In-Reply-To: <marc-linux-ia64-106989195923088@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Nov 2003 12:12:56 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Wed, 26 Nov 2003 16:32:00 -0800, 
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >>>>>>> On Thu, 27 Nov 2003 11:12:18 +1100, Keith Owens <kaos@sgi.com> said:
  Keith> We need a generic fix for unwinding through out of line code
  Keith> called from leaf functions and not using br.call.  The
  Keith> obvious solution is to flag all out of line code with an
  Keith> unwind abi field and have the common unwind code reset
  Keith> ar.pfs.  Can I use .unwabi 3, 'o' for out of line?

  >> The .unwabi directive isn't appropriate for that.  If you want such a
  >> feature, please push it through the ABI committee to get it officially
  >> supported.  I've said that before, I think.

  Keith> I disagree, unwabi is exactly what we need for this.  The out
  Keith> of line code is peculiar to Linux, and uses the Linux pt_regs
  Keith> to get the real ar.pfs.  .unwabi 3,i indicates a Linux
  Keith> interrupt frame with all state in pt_regs, .unwabi 3,o
  Keith> indicates a Linux out of line frame with pt_regs.ar_pfs
  Keith> containing the real ar.pfs.  If unwabi 3,i is valid then so
  Keith> is unwabi 3,o.

If you want to support out-of-line code, do it right or don't it at
all.  There is no chance in hell I'm going to accept such hacks and I
also won't bother supporting such gross hacks in libunwind.  EOD.

	--david
