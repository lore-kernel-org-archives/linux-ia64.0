From: Will Deacon <will.deacon@arm.com>
Date: Thu, 28 Jan 2016 14:39:26 +0000
Subject: Re: [PATCH v9 3/6] arm64/arm, numa, dt: adding numa dt binding implementation for arm64 platforms.
Message-Id: <20160128143925.GC775@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1453134965-6125-1-git-send-email-gkulkarni@caviumnetworks.com>
 <1453134965-6125-4-git-send-email-gkulkarni@caviumnetworks.com>
 <20160126203603.GC17600@localhost>
In-Reply-To: <20160126203603.GC17600@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <helgaas@kernel.org>
Cc: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-arch@vger.kernel.org, catalin.marinas@arm.com, grant.likely@linaro.org, leif.lindholm@linaro.org, rfranz@cavium.com, ard.biesheuvel@linaro.org, msalter@redhat.com, robh+dt@kernel.org, steve.capper@linaro.org, hanjun.guo@linaro.org, al.stone@linaro.org, arnd@arndb.de, pawel.moll@arm.com, mark.rutland@arm.com, ijc+devicetree@hellion.org.uk, galak@codeaurora.org, rjw@rjwysocki.net, lenb@kernel.org, marc.zyngier@arm.com, lorenzo.pieralisi@arm.com, bhelgaas@google.com, tony.luck@intel.com, fenghua.yu@intel.com, james.hogan@imgtec.com, benh@kernel.crashing.o

On Tue, Jan 26, 2016 at 02:36:04PM -0600, Bjorn Helgaas wrote:
> Subject is "arm64/arm, numa, dt: adding ..."  What is the significance
> of the "arm" part?  The other patches only mention "arm64".
> 
> General comment: the code below has little, if anything, that is
> actually arm64-specific.  Maybe this is the first DT-based NUMA
> platform?  I don't see other similar code for other arches, so maybe
> it's too early to try to generalize it, but we should try to avoid
> adding duplicates of this code if/when other arches do show up.

Having it in the core code would allow us to share it with arch/arm/
fairly straightforwardly.

Will
