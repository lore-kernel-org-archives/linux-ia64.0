From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 02 Apr 2004 17:07:48 +0000
Subject: Re: [Linux-ia64] elilo-3.0 PXE mode fix
Message-Id: <20040402170748.GA688@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B0547D016@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack,

On Fri, Apr 02, 2004 at 03:06:34PM +0800, Li, Jack wrote:
> 
> I am also trying to setup PXE for IA64. Could you send a copy of your
> pxe.conf file to me? And the boot strap you are using?  Thanks. 
> 
I suggest you use elilo-3.4 instead of 3.0. The package contains an
example of the dcph/pxe setup I used to test this. The problem was
that the ISC DHCPD needed some extensions to support PXE/Ia64. Those
extensions were added by Intel but I don't know if they ever made it
into the official ISC DHCPD server, you'd have to check.

Anyway, in the elilo-3.4 package, go to examples/netboot. You'll
find a PXE config file.

Hope this helps.

PS: Brett Johnson is the new maintainer of the package and he has setup 
a SourceForge web for elilo: http://elilo.sf.net

-- 

-Stephane
