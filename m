From: Keith Owens <kaos@sgi.com>
Date: Mon, 13 Feb 2006 21:26:47 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <21300.1139866007@ocs3>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian (on Mon, 13 Feb 2006 12:12:39 -0800) wrote:
>Jes seems to believe than this is more historical than anything for qla2xxx.
>Now what about the timer interrupt, why does it really need SA_INTERRUPT especially
>given that it is so high priority and with the TPR mechanism. IT seems to be
>a protection against MCA, IPI, IPI_RESCHEDULE based on the current layout.

Nit pick, the time interrupt will hold off any MCA slave rendezvous,
but not the MCA monarch event.  The latter is not masked by the kernel,
except where it is already processing an MCA monarch or INIT
monarch/slave event.

