From: Li kunyu <kunyu@nfschina.com>
Date: Fri, 10 Jun 2022 15:17:04 +0000
Subject: Re: [PATCH] x86: Change the return type of acpi_map_cpu2node to void
Message-Id: <20220610151705.8383-1-kunyu@nfschina.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7eb4762e-723b-51e8-3d70-1c28568ac4f5@intel.com>
In-Reply-To: <7eb4762e-723b-51e8-3d70-1c28568ac4f5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dave.hansen@intel.com
Cc: bp@alien8.de, chenhuacai@kernel.org, dave.hansen@linux.intel.com, hpa@zytor.com, kunyu@nfschina.com, len.brown@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, mingo@redhat.com, pavel@ucw.cz, rafael@kernel.org, tglx@linutronix.de, x86@kernel.org


I'm really sorry, Dave. My email prompted abnormal sending (when I sent patch before), so I sent it three times, but there was no abnormal message for the third time.

Static functions are called from the current source file, and their basic functions are similar to global functions (perhaps I don't fully understand).

In addition, the x86 architecture is EAX in the IA64 architecture did not pay much attention, which is my oversight.
