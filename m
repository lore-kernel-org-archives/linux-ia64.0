From: "Carron, Thierry" <thierry.carron@hp.com>
Date: Mon, 27 Jan 2003 17:21:00 +0000
Subject: RE: [Linux-ia64] Re: VM strict overcommit on RedHat AS 2.1 kernel 2.4.18-e12 ?
Message-Id: <marc-linux-ia64-105590709805754@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805753@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805753@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Hi,

in the file : Documentation/vm/overcommit-accounting :

The Linux kernel supports four overcommit handling modes

0       -       Heuristic overcommit handling. Obvious overcommits of
                address space are refused. Used for a typical system. It
                ensures a seriously wild allocation fails while allowing
                overcommit to reduce swap usage

1       -       No overcommit handling. Appropriate for some scientific
                applications

2       -       (NEW) strict overcommit. The total address space commit
                for the system is not permitted to exceed swap + half ram.
                In almost all situations this means a process will not be
                killed while accessing pages but only by malloc failures
                that are reported back by the kernel mmap/brk code.

3       -       (NEW) paranoid overcommit The total address space commit
                for the system is not permitted to exceed swap. The machine
                will never kill a process accessing pages it has mapped
                except due to a bug (ie report it!)

in the source code : mm/mmap.c
int vm_enough_memory(long pages, int charge)
{
        /* Stupid algorithm to decide if we have enough memory: while
         * simple, it hopefully works in most obvious cases.. Easy to
         * fool it, but this should catch most mistakes.
         *
         * 23/11/98 NJC: Somewhat less stupid version of algorithm,
         * which tries to do "TheRightThing".  Instead of using half of
         * (buffers+cache), use the minimum values.  Allow an extra 2%
         * of num_physpages for safety margin.
         *
         * 2002/02/26 Alan Cox: Added two new modes that do real accounting
         */
        unsigned long free, allowed;
        struct sysinfo i;

        if(charge)
                atomic_add(pages, &vm_committed_space);

        /* Sometimes we want to use more memory than we have. */
        if (sysctl_overcommit_memory =3D=3D 1)
            return 1;
        if (sysctl_overcommit_memory =3D=3D 0)
        {
          .....
        }
        if(sysctl_overcommit_memory =3D=3D 2)
        {
                /* FIXME - need to add arch hooks to get the bits we need
                   without the higher overhead crap */
                si_meminfo(&i);
                allowed +=3D i.totalram >> 1;
        }
        if(atomic_read(&vm_committed_space) < allowed)
                return 1;
        if(charge)
                atomic_sub(pages, &vm_committed_space);
        return 0;

}
Regards,
Thierry
PS: Unfortunatelly I will be out of office until the 3rd Febuary with no ac=
cess to my mail box.


-----Message d'origine-----
De : Bill Nottingham [mailto:notting@redhat.com]
Envoy=E9 : lundi 27 janvier 2003 17:36
=C0 : Carron, Thierry
Cc : linux-ia64@linuxia64.org
Objet : [Linux-ia64] Re: VM strict overcommit on RedHat AS 2.1 kernel
2.4.18-e12 ?


Carron, Thierry (thierry.carron@hp.com) said:=20
> I know that Alan Cox has a patch and that a lot of job is currently done =
in kernel 2.5 .
> This patch is partially integrated in the kernel 2.4.18-e12 delivered wit=
h the RedHat Advanced Server 2.1.=20
> But there is a difference between the documentation  about overcommit_mem=
ory  in sysctl/vm.txt and the code really implemented in mm/mmap.c
> Is there any reason for that ?

What differences are you seeing between the documentation and the
code?

Bill

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

