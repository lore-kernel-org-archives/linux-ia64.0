From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Sep 2003 15:26:16 +0000
Subject: Re: perfmon1 fix for 2.4
Message-Id: <marc-linux-ia64-106268979228780@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 03 September 2003 3:26 pm, Stephane Eranian wrote:
> Bjorn,
> 
> Please apply this patch to perfmon1 in your 2.4 kernel. 
> 
> Changelog:
> 
> - fixes a problem with the rum/sum instructions being inoperative even at priv level zero 
>   when psr.sp=0. Switching to ssm/rsm fixes the potential problem.

I applied this, thanks.

General note to everybody: When sending patches, it makes my life easier
if they apply with "patch -p1" and if you copy the linux-ia64 list.

And though it doesn't apply in this case because 2.5 has perfmon2, it
never hurts to diff the files you touch with the corresponding files
in linux-2.5.  (I do that routinely, and if your patch introduces
spurious whitespace differences, I have to clean them up by hand.)

Bjorn

