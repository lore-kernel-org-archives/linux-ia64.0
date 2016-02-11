From: Rob Herring <robh+dt@kernel.org>
Date: Thu, 11 Feb 2016 14:50:41 +0000
Subject: Re: [PATCH v10 3/8] dt, numa: adding numa dt binding implementation.
Message-Id: <CAL_JsqK5HV9yzBE+ANnTw26eVR7Dy+B8OkwQ-7WF8KDa86Fd9g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454407763-1017-1-git-send-email-gkulkarni@caviumnetworks.com> <1454407763-1017-4-git-send-email-gkulkarni@caviumnetworks.com>
In-Reply-To: <1454407763-1017-4-git-send-email-gkulkarni@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-metag <linux-metag@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Will Deacon <Will.Deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Grant Likely <grant.likely@linaro.org>, Leif Lindholm <leif.lindholm@linaro.org>, rfranz@cavium.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Mark Salter <msalter@redhat.com>, Steve Capper <steve.capper@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Al

On Tue, Feb 2, 2016 at 4:09 AM, Ganapatrao Kulkarni
<gkulkarni@caviumnetworks.com> wrote:
> dt node parsing for numa topology is done using device property
> numa-node-id and device node distance-map.

How is it that powerpc doesn't need flat DT parsing for NUMA? Both
arches are memblock based and the binding is similar IIRC, so you
should be able to find a way to do this with the unflattened tree.
Ideally, there should be some common code shared as well.

Do you have a git tree with this series?

Rob
