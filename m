From: Vaibhav Sharma <vaibhav.sh@gmail.com>
Date: Thu, 03 Feb 2005 07:15:40 +0000
Subject: Re: IA64 memory
Message-Id: <851caabb0502022303709136b@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <851caabb05020220513945437@mail.gmail.com>
In-Reply-To: <851caabb05020220513945437@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,
Thanks a lot for a quick response, I appreciate.
If you could only help me out a little more =E2=80=A6.=20

See, I need to change some of the boot parameters as read/seen by the
kernel. Once these parameters have been setup by elilo, the Kernel
must read it from these predefined areas in memory, into some of its
variables. I need to understand where this reading part happens in the
kernel. This is where I want to modify the resources, for future use
by the kernel !! I don't want to touch the elilo source, only the
kernel.

Hoping to hear from you soon.

Thanks and Regards,
Vaibhav.



On Wed, 2 Feb 2005 22:01:14 -0800, David Mosberger
<davidm@napali.hpl.hp.com> wrote:
> >>>>> On Thu, 3 Feb 2005 10:21:42 +0530, Vaibhav Sharma <vaibhav.sh@gmail=
.com> said:
>=20
>   Vaibhav> Hi, I am investigating how linux initializes the memory in
>   Vaibhav> IA64 machine.  the flow, very broadly (i think) is:
>   Vaibhav> **start_kernel-> setup_arch-> find_memory-> efi_memmap_walk
>   Vaibhav> ** ( it does all all other things like unwind_init,
>   Vaibhav> efi_init, etc, inbetween).  The function efi_memmap_walk
>   Vaibhav> uses the "IA64_boot_param" structure to read the memory
>   Vaibhav> map. I wanted to know where and how this structure is
>   Vaibhav> initialized, I mean how does it access the EFI table.  Are
>   Vaibhav> call-backs used to initialize this structure..??..Do these
>   Vaibhav> call-backs use the API's to EFI table management...?
>=20
> The boot-param structure is setup by elilo.
>=20
> Look for a routine called sysdeps_create_boot_params() in the elilo sourc=
es.
>=20
>         --david
>
