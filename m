From: Keith Owens <kaos@sgi.com>
Date: Thu, 27 Nov 2003 01:12:56 +0000
Subject: Re: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-106989572025875@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106989195923088@msgid-missing>
In-Reply-To: <marc-linux-ia64-106989195923088@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 26 Nov 2003 16:32:00 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Thu, 27 Nov 2003 11:12:18 +1100, Keith Owens <kaos@sgi.com> said:
>  Keith> We need a generic fix for unwinding through out of line code
>  Keith> called from leaf functions and not using br.call.  The
>  Keith> obvious solution is to flag all out of line code with an
>  Keith> unwind abi field and have the common unwind code reset
>  Keith> ar.pfs.  Can I use .unwabi 3, 'o' for out of line?
>
>The .unwabi directive isn't appropriate for that.  If you want such a
>feature, please push it through the ABI committee to get it officially
>supported.  I've said that before, I think.

I disagree, unwabi is exactly what we need for this.  The out of line
code is peculiar to Linux, and uses the Linux pt_regs to get the real
ar.pfs.  .unwabi 3,i indicates a Linux interrupt frame with all state
in pt_regs, .unwabi 3,o indicates a Linux out of line frame with
pt_regs.ar_pfs containing the real ar.pfs.  If unwabi 3,i is valid then
so is unwabi 3,o.

