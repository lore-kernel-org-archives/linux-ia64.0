From: Tony Luck <tony.luck@gmail.com>
Date: Tue, 24 Jan 2017 18:23:41 +0000
Subject: Re: [PATCH v4 2/5] ia64: reuse append_elf_note() and final_note() functions
Message-Id: <CA+8MBb+g604VGLLibB+eOAtF_h1r5mYJRdjaGE8UgWQ+JPGDdg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148363729327.11570.6244765717789390817.stgit@hbathini.in.ibm.com>
 <148363740554.11570.4870634597647436827.stgit@hbathini.in.ibm.com>
 <20170106020324.GB2863@dhcp-128-65.nay.redhat.com> <38a7807c-cd95-670d-30d3-c45e7921ea11@linux.vnet.ibm.com>
 <0748026f-a459-9022-3658-a75cb0633f40@linux.vnet.ibm.com>
In-Reply-To: <0748026f-a459-9022-3658-a75cb0633f40@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Dave Young <dyoung@redhat.com>, kexec-ml <kexec@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, "vgoyal@redhat.com" <vgoyal@redhat.com>

On Tue, Jan 24, 2017 at 10:11 AM, Hari Bathini
<hbathini@linux.vnet.ibm.com> wrote:

> Hello IA64 folks,
>
> Could you please review this patch..?

It looks OK in principal.  My lab is in partial disarray at the
moment (just got back from a sabbatical) so I can't test
build and boot. Have you cross-compiled it (or gotten a success
build report from zero-day)?

If you have ... then add an Acked-by: Tony Luck <tony.luck@intel.com>

-Tony
