From: david mosberger <dmosberger@gmail.com>
Date: Thu, 01 Sep 2005 01:38:09 +0000
Subject: Re: testing mca/init patch
Message-Id: <ed5aea43050831183858dd0c24@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
In-Reply-To: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On 8/31/05, tony.luck@intel.com <tony.luck@intel.com> wrote:

> To make life easier for testers, I've applied Keith's patches
> and put them into my test tree.
>
> [snip...]
>
> The above is at least as good as the previous behaivour, but something
> bad happened there at the end.  There were also more delays than I
> was expecting.

I tried this quickly on a zx2000 and didn't see any additional delays.
 Output looked like this:

---------------------------------------------------------
login: (
cli>toc s
Sending TOC/INIT.
Entered OS INIT handler. PSP=FFe301a0
Delaying for 5 seconds...
Processes interrupted by INIT - 0 (cpu 0 task 0xa000000100808000)


Backtrace of pid 1 (init)

Call Trace:
 [<a0000001006bca70>] schedule+0x950/0x10c0
                                sp=E000000001167d90 bsp=E000000001161088
 [<a0000001006bde10>] schedule_timeout+0xd0/0x1a0
                                sp=E000000001167d90 bsp=E000000001161058
 [<a00000010015c000>] do_select+0x3e0/0x7c0
                                sp=E000000001167dd0 bsp=E000000001160f08
 [<a00000010015d1d0>] sys_select+0x4f0/0x900
                                sp=E000000001167df0 bsp=E000000001160e40
 [<a00000010000b320>] ia64_ret_from_syscall+0x0/0x20
                                sp=E000000001167e30 bsp=E000000001160e40
 [<a000000000010620>] __start_ivt_text+0xffffffff00010620/0x400
                                sp=E000000001168000 bsp=E000000001160e40

 [snip...]

Backtrace of pid 4352 (bash)

Call Trace:
 [<a0000001006bca70>] schedule+0x950/0x10c0
                                sp=E00000404574fdb0 bsp=E000004045749308
 [<a0000001006bde70>] schedule_timeout+0x130/0x1a0
                                sp=E00000404574fdb0 bsp=E0000040457492d8
 [<a0000001003c2040>] read_chan+0x560/0x13e0
                                sp=E00000404574fdf0 bsp=E0000040457491a8
 [<a0000001003b51b0>] tty_read+0x130/0x1a0
                                sp=E00000404574fe20 bsp=E000004045749158
 [<a00000010012d160>] vfs_read+0x1e0/0x340
                                sp=E00000404574fe20 bsp=E000004045749100
 [<a00000010012e3b0>] sys_read+0x70/0xe0
                                sp=E00000404574fe20 bsp=E000004045749088
 [<a00000010000b320>] ia64_ret_from_syscall+0x0/0x20
                                sp=E00000404574fe30 bsp=E000004045749088
 [<a000000000010620>] __start_ivt_text+0xffffffff00010620/0x400
                                sp=E000004045750000 bsp=E000004045749088

INIT dump complete.  Monarch on cpu 0 returning to normal service.
---------------------------------------------------------

I didn't see any delays other than the expected 5 sec delay.

  --david
--=20
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
