From: Dave Hansen <dave.hansen@intel.com>
Date: Fri, 10 Jun 2022 12:35:29 +0000
Subject: Re: [PATCH] x86: Change the return type of acpi_map_cpu2node to void
Message-Id: <7eb4762e-723b-51e8-3d70-1c28568ac4f5@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610104423.201739-1-kunyu@nfschina.com>
In-Reply-To: <20220610104423.201739-1-kunyu@nfschina.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Li kunyu <kunyu@nfschina.com>, chenhuacai@kernel.org, rafael@kernel.org, len.brown@intel.com, pavel@ucw.cz, mingo@redhat.com, bp@alien8.de
Cc: tglx@linutronix.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org

On 6/10/22 03:44, Li kunyu wrote:
> Reduce eax register calls by removing unused return values.

Please stop sending these patches, at least with these repetitive,
inaccurate descriptions.

This patch has *ZERO* to do with EAX.  For one, it's patching two
architectures that might not even have an EAX.  (I'm blissfully unaware
of what the ia64 calling conventions are and I want to keep it that way.)

Second, (and this is important), look carefully at the function in question:

static int acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)

See the "static"?  That tells the compiler that acpi_map_cpu2node() is
only used locally.  It lets the compiler do all kinds of fancy things,
like inline the function which allows the compiler to do all kinds of
fun optimizations.  Now, armed with that knowledge, please take a look
at what effect your patch has in practice.

Take your patch, and disassemble acpi_map_cpu() before and after
applying it.  First of all, even before your patch, do you see a:

	call ffffffff81d0000d <acpi_map_cpu2node>

?

Do you see a call to numa_set_node()?  That's odd considering that
acpi_map_cpu() doesn't directly call numa_set_node().  Right?  Do you
see unnecessary manipulation of EAX?  Now, apply your patch.
Disassemble the function again.  What changed?

Now, armed with the knowledge of what your patch actually does to the
code, would you like to try and write a better changelog?  Or, better
yet, maybe it will dissuade you from sending this again.
