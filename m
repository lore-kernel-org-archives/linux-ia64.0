From: David Daney <ddaney.cavm@gmail.com>
Date: Mon, 18 Jan 2016 17:49:56 +0000
Subject: Re: [PATCH v9 4/6] arm64, dt, thunderx: Add initial dts for Cavium Thunderx in 2 node topology.
Message-Id: <569D25C4.3060806@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com> <1453134965-6125-5-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1453134965-6125-5-git-send-email-gkulkarni@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Cc: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, Will.Deacon@arm.com, catalin.marinas@arm.com, grant.likely@linaro.org, leif.lindholm@linaro.org, rfranz@cavium.com, ard.biesheuvel@linaro.org, msalter@redhat.com, robh+dt@kernel.org, steve.capper@linaro.org, hanjun.guo@linaro.org, al.stone@linaro.org, arnd@arndb.de, pawel.moll@arm.com, mark.rutland@arm.com, ijc+devicetree@hellion.org.uk, galak@codeaurora.org, rjw@rjwysocki.net, lenb@kernel.org, marc.zyngier@arm.com, lorenzo.pieralisi@arm.com, bhelgaas@google.com, tony.luck@intel.com, fenghua.yu@intel.com, james.hogan@imgtec.com, benh@kernel.crashing.org, tglx@linutronix.de, mingo@r

On 01/18/2016 08:36 AM, Ganapatrao Kulkarni wrote:
> Adding dt file for Cavium's Thunderx dual socket platform.
>
> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> ---
>   arch/arm64/boot/dts/cavium/Makefile             |   2 +-
>   arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts  |  83 +++
>   arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi | 806 ++++++++++++++++++++++++
>   3 files changed, 890 insertions(+), 1 deletion(-)
>   create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dts
>   create mode 100644 arch/arm64/boot/dts/cavium/thunder-88xx-2n.dtsi
>

These files are useless, they don't contain device nodes for anything 
other than the UARTs.  There is no existing system that has only UARTs 
and no other devices, so these files cannot be (and can never be) used 
anywhere.

Since the boot firmware in all real, and emulated, systems is supplying 
correct DTBs, we should consider not merging these files, and removing 
the likewise useless thunder-88xx.dts  thunder-88xx.dtsi

David Daney


[...]
