From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Tue, 07 Feb 2017 09:29:03 +0000
Subject: Re: [PATCH] x86/acpi: keep x86_cpu_to_acpiid mapping valid on cpu hotplug
Message-Id: <87shnqs61s.fsf@vitty.brq.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170206170151.25542-1-vkuznets@redhat.com>
        <CAJZ5v0i83hgXVymsdpLTGxrChy0qMpdbQR3Lzqvt3fFMzoaxxw@mail.gmail.com>
In-Reply-To: <CAJZ5v0i83hgXVymsdpLTGxrChy0qMpdbQR3Lzqvt3fFMzoaxxw@mail.gmail.com>
        (Rafael J. Wysocki's message of "Mon, 6 Feb 2017 22:05:57 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: the arch/x86 maintainers <x86@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Jones <drjones@redhat.com>

"Rafael J. Wysocki" <rafael@kernel.org> writes:

> On Mon, Feb 6, 2017 at 6:01 PM, Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>> We may or may not have all possible CPUs in MADT on boot but in any case
>> we're overwriting x86_cpu_to_acpiid mapping with U32_MAX when
>> acpi_register_lapic() is called again on the CPU hotplug path:
>> acpi_processor_hotadd_init() -> acpi_map_cpu() -> acpi_register_lapic().
>>
>> As we have the required acpi_id information in acpi_processor_hotadd_init()
>> propagate it to acpi_map_cpu() to always keep x86_cpu_to_acpiid mapping
>> valid.
>>
>> Reported-by: Andrew Jones <drjones@redhat.com>
>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>
> Is the bug report available and if so, do you have a pointer to it?
>

There was no 'real' bug, the issue was found by code inspection.
Potentially, the following scenario is currently broken:
- boot Xen HVM guest and do kdump on a secondary CPU
- with kdump kernel running try to hot-plug additional CPUs.
we'll end up with U32_MAX in x86_cpu_to_acpiid for hot-plugged CPUs so
we'll be assuming direct Linux<->Xen mapping which won't be the case and
all hypercalls referring to these CPUs will end up affecting some other
CPUs.

-- 
  Vitaly
