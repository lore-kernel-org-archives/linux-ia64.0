From: Matthew Wilcox <willy@debian.org>
Date: Thu, 16 Oct 2003 19:40:22 +0000
Subject: Re: PATCH 2.4.23-pre6 add kmap_types.h for CONFIG_CRYPTO
Message-Id: <marc-linux-ia64-106633326623979@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106633278923482@msgid-missing>
In-Reply-To: <marc-linux-ia64-106633278923482@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Oct 16, 2003 at 12:29:58PM -0700, Grant Grundler wrote:
> This doesn't feel like a great solution.
> Willy suggested the right fix might be to not require all arches to
> provide asm/kmap_types.h.  I'll let the folks who know WTH kmap_types.h
> is really for debate and submit this with the hope of getting the
> ia64-linux to build with CONFIG_CRYPTO.

Cloning kmap_types from i386 is a pretty bad idea since that architecture
actually supports highmem.  Better to clone from an arch which has no
support for highmem such as ARM.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
