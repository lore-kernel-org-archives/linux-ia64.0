From: Matthew Wilcox <willy@debian.org>
Date: Wed, 18 Jun 2003 23:00:21 +0000
Subject: Re: ACPI vs PCI: configuration space
Message-Id: <marc-linux-ia64-105597765010846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105597468808360@msgid-missing>
In-Reply-To: <marc-linux-ia64-105597468808360@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2003 at 03:30:03PM -0700, Greg KH wrote:
> So for i386, what would domain be?

The `seg' argument currently in place to all these macros ;-)

> Anyway, yeah, I agree with try 5, that seems the most sane.

Yay.  you'll have a patch tomorrow.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
