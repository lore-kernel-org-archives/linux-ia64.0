From: Mark Salter <msalter@redhat.com>
Date: Sun, 15 Dec 2013 15:50:26 +0000
Subject: Re: [PATCH 10/10] Kconfig: cleanup SERIO_I8042 dependencies
Message-Id: <1387122626.1979.136.camel@deneb.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1387040376-26906-1-git-send-email-msalter@redhat.com>
 <1387040376-26906-11-git-send-email-msalter@redhat.com>
 <52ACA43F.2040402@zytor.com>
 <20131215103657.GB20197@core.coreip.homeip.net>
In-Reply-To: <20131215103657.GB20197@core.coreip.homeip.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Sun, 2013-12-15 at 02:36 -0800, Dmitry Torokhov wrote:
> On Sat, Dec 14, 2013 at 10:32:31AM -0800, H. Peter Anvin wrote:
> > On 12/14/2013 08:59 AM, Mark Salter wrote:
> > > Remove messy dependencies from SERIO_I8042 by having it depend on one
> > > Kconfig symbol (ARCH_MIGHT_HAVE_PC_SERIO) and having architectures
> > > which need it select ARCH_MIGHT_HAVE_PC_SERIO in arch/*/Kconfig.
> > > New architectures are unlikely to need SERIO_I8042, so this avoids
> > > having an ever growing list of architectures to exclude.

> How are we going to merge this? In bulk through input tree or peacemeal
> through all arches first?
> 

They should all go together to eliminate the chance of bisect breakage.
Either the input tree or maybe akpm tree.


