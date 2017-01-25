From: Hari Bathini <hbathini@linux.vnet.ibm.com>
Date: Wed, 25 Jan 2017 19:27:52 +0000
Subject: Re: [PATCH v4 2/5] ia64: reuse append_elf_note() and final_note() functions
Message-Id: <04b96f50-f77d-9446-975f-7d44accfe583@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <148363729327.11570.6244765717789390817.stgit@hbathini.in.ibm.com>
 <148363740554.11570.4870634597647436827.stgit@hbathini.in.ibm.com>
 <20170106020324.GB2863@dhcp-128-65.nay.redhat.com>
 <38a7807c-cd95-670d-30d3-c45e7921ea11@linux.vnet.ibm.com>
 <0748026f-a459-9022-3658-a75cb0633f40@linux.vnet.ibm.com>
 <CA+8MBb+g604VGLLibB+eOAtF_h1r5mYJRdjaGE8UgWQ+JPGDdg@mail.gmail.com>
In-Reply-To: <CA+8MBb+g604VGLLibB+eOAtF_h1r5mYJRdjaGE8UgWQ+JPGDdg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@gmail.com>
Cc: "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Dave Young <dyoung@redhat.com>, kexec-ml <kexec@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, "vgoyal@redhat.com" <vgoyal@redhat.com>



On Tuesday 24 January 2017 11:53 PM, Tony Luck wrote:
> On Tue, Jan 24, 2017 at 10:11 AM, Hari Bathini
> <hbathini@linux.vnet.ibm.com> wrote:
>
>> Hello IA64 folks,
>>
>> Could you please review this patch..?
> It looks OK in principal.  My lab is in partial disarray at the
> moment (just got back from a sabbatical) so I can't test
> build and boot. Have you cross-compiled it (or gotten a success
> build report from zero-day)?

I haven't gotten a success/failure build report from zero-day. Not sure 
what to make of it.
But I did try cross-compiling and it was successful. Should that do?

Thanks
Hari


> If you have ... then add an Acked-by: Tony Luck <tony.luck@intel.com>
>
> -Tony
>

