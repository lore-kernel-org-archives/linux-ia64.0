From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 30 Oct 2002 17:37:23 +0000
Subject: Re: [Linux-ia64] PXE boot off HP zx6000
Message-Id: <marc-linux-ia64-105590709805301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805294@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805294@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jason,

There are two different ways of netbooting on EFI-based systems.
EFI supports both PXE and regular DHCP. The client will first try PXE if
it fails, then it defaults to DHCP. Elilo supports both. However any 
existing Linux (IA-32) PXE server WILL NOT WORK for IA-64 clients because
some special support is needed on the server side. None of that support
has made it into the official DHCP server as released by ISC (www.isc.org).
This server is the base for the one used by Redhat, for instance. Intel has 
created a patch for it and it is still waiting for it to be integrated into 
the main codebase. As such, the situation on the PXE side is not that good. 
I have tested elilo with the patched version and I know it works, but it is
not available at this point. For now, I recommend using regular DHCP. This 
works out of the box on existing IA-32 Redhat systems as you can see by 
yourself now that your problem is fixed.

Your dhcpd.config can be as indicated by Alex.

> > /etc/dhcpd.conf
> >         host zx6000 { 
> >                 hardware ethernet xx:xx:xx:xx:xx:xx;
> >                 fixed-address zx6000;
> >                 filename "elilo.efi";
> >         }
> > 

Then elilo can download its configuation file, the kernel image and initrd
from the DHCP/TFTP server. For the configuration file, elilo will look for
a  first match  in the following order:

	1) a client-specific file: AABBCCDD.conf where AABBCCDD is the 
	   captilized hexadecimal representation of the IP address assigned 
	   by the DHCP server. For instance, if the IP address is 15.4.89.69, 
	   then the file must be 0F045945.conf.

	2) an architecture-specific file: elilo-ia64.conf if the client is
	   an IA-64 machine. elilo-ia32.conf if coming from an IA-32 client.

	3) a generic file: elilo.conf

Hope this helps.

-- 

-Stephane

