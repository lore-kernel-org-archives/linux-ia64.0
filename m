From: Brett Johnson <brett@fc.hp.com>
Date: Fri, 02 Apr 2004 23:47:54 +0000
Subject: RE: [Linux-ia64] elilo-3.0 PXE mode fix
Message-Id: <1080949673.22058.5.camel@raphael.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 2004-04-02 at 16:30, Li, Jack wrote:
> I don't have access to the DHCP server. I can only configure the PXE
> server which is full under my control. I don't think the dhcpd-pxe.conf
> can be used for the RedHat PXE server (pxe-0.1-36). Right?

No, the config files are quite different.  I don't know if the pxe
server will boot an ia64 machine, since I've never tried it.  Googleing
around, I found a sample pxe config in the mandrake docs, which actually
has the token "IA64EFI" in it.  I have no clue what the token means, but
it has all the right letters :o)

  http://clic.mandrakesoft.com/documentation/pxe/ch03.html

Cheers!
-- 
Brett Johnson <brett@hp.com>
   -  i  n  v  e  n  t  -
