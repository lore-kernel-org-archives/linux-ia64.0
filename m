From: Brett Johnson <brett@hp.com>
Date: Fri, 02 Apr 2004 23:19:10 +0000
Subject: RE: [Linux-ia64] elilo-3.0 PXE mode fix
Message-Id: <1080947949.20981.49.camel@raphael.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-04-02 at 14:19, Li, Jack wrote:
> Thank you. But I am using the PXE of a RedHat 9.0. So do you know if
> this PXE server can support IA64? Do you have a sample pxe.conf for the
> PXE server?

I don't have a redhat9 machine, but based on what I see on rpmfind.net,
it looks like they're using dhcp 3.0p1, which should work fine.

As Stephane mentioned, there is an example config in the elilo
"netbooting.txt" document.  You can get it from

http://cvs.sourceforge.net/viewcvs.py/elilo/elilo/docs/netbooting.txt

If you don't have a local copy.

Cheers!
-- 
Brett Johnson <brett@hp.com>
   -  i  n  v  e  n  t  -
