From: "Egan Ford" <egan@sense.net>
Date: Wed, 16 Jan 2002 18:59:04 +0000
Subject: RE: [Linux-ia64] PXE Boot
Message-Id: <marc-linux-ia64-105590698805852@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I cannot tell you what the problem is, but can tell you what I do:

Here is my DHCP entry (I still use DHCP v2):

	subnet 199.88.179.0 netmask 255.255.255.0 {
		default-lease-time		-1;
		option routers			199.88.179.1;
		option subnet-mask		255.255.255.0;
		option nis-domain			"sensenet";
		option domain-name		"sense.net";
		option domain-name-servers	199.88.179.22;
		option time-offset		-7;

		host node8 {
			hardware ethernet 00:03:47:13:83:3F;
			fixed-address 199.88.179.208;
			filename "/tftpboot/elilo.efi";
			next-server 199.88.179.22;
		}
	}

I use atftpd as my tftpd server.  I have tested and used elilo 2.5 and 3.x
with no problems.

Here is my .conf for installation:

#install user71-ia64-ia64
prompt
timeoutP
default=install

image=xcat/ks71-ia64z
	append="console=ttyS0,9600
ks=nfs:jupiter:/install/ks71-ia64/user71-ia64-ia64.ks ksdevice=eth0"
 	label=install
	read-only
	initrd=xcat/ks71-ia64.gz



> -----Original Message-----
> From: linux-ia64-admin@linuxia64.org
> [mailto:linux-ia64-admin@linuxia64.org]On Behalf Of Stephane Eranian
> Sent: Wednesday, January 16, 2002 11:24 AM
> To: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] PXE Boot
>
>
> Mike,
>
> On Wed, Jan 16, 2002 at 10:57:25AM -0800, Michael Madore wrote:
> >
> > I'm trying to boot a Big Sur workstation (Firmware 117C) via the
> > network.  The workstation receives an address via dhcp and when starting
> > to download elilo.efi I get the following error message:
> >
> > PXE-E05: Download buffer is smaller than requested file.
> > Load of PXE boot failed:  File not found
> >
> Do you get this everytime? I have already seen this problem but
> it disappears
> if you retry, if I recall correctly.
>
> > Does this message really indicate the buffer is to small, or is this a
> > symptom of a different problem?
> >
> Are you using a PXE-aware DHCP server or a standard DHCP server?
>
>
> --
>
> -Stephane
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64


