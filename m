From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Tue, 23 Jul 2002 18:08:42 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905823@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Jul 2002 14:09:55 +0200
Andreas Schwab <schwab@suse.de> wrote:

> David Mosberger <davidm@napali.hpl.hp.com> writes:
> 
> |> ChangeLog
> |> 
> |> - Make "xconfig" work again (Keith Owens, Khalid Aziz)
> |> - Add HCDP ACPI serial line support (Khalid Aziz)
> |> - Drop extraneous set_rte() call from iosapic.c (Alex Williamson)
> |> - Fix perfmon SMP initialization ordering bug (Stephane Eranian)
> |> - Include perfmon_mckinley.h now that it's public info (Stephane Eranian)
> |> - Implement pcibios_enable_device for PCI hotplug (Takayoshi Kochi)
> 
> Compiling pcihpacpi as module requires acpi_walk_namespace to be
> exported from the kernel.

Excuse me,

pcihpacpi is an old module that *cannot* do real PCI hotplug and
isn't included in 2.4.18 ia64 patch (it's included after 2.4.19-pre2).
So don't bother David:)

Recently I posted to a new version of ACPI PCI hotplug to the PCI
hotplug maintainer, and it works for some PCI hot-pluggable platforms,
but you may need some extra patches.

For those who would like to play with PCI hotplug with ACPI,
I'll post patches necessary for the latest 2.4.18 patch later on
today.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


