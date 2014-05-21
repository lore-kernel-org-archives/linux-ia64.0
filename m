From: =?UTF-8?Q?=C3=89meric_MASCHINO?= <emeric.maschino@gmail.com>
Date: Wed, 21 May 2014 22:09:54 +0000
Subject: Re: [regression][bisected] zx1 AGP GART no more detected since merge of 'acpi-scan' branch
Message-Id: <CAA9xbM7t-aBtr+80Crnd0tuRuwKwFP_NSPW1VKL345rCivAsog@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
In-Reply-To: <CAA9xbM4=Rt3hVYEUv2GoWNex8cCeaxnBUWEc4_6mF_cLRLZZ2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi Rafael,

2014-05-21 21:09 GMT+02:00 Rafael J. Wysocki <rafael.j.wysocki@intel.com>:
> Hi,
>
> Quite evidently, acpi_sba_ioc_add() has to be executed after
> acpi_pci_root_add()
> and we need to enforce that ordering somehow.
>
> Please create a bug entry for that at bugzilla.kernel.org (against ACPI),
> mark it as a regression and
> assign it to rjw@rjwysocki.net.

Allright here's the bugzilla entry:
https://bugzilla.kernel.org/show_bug.cgi?idv691

Feel free to ask for more tests, if required.

Thanks,

     =C3=89meric
