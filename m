From: Matthew Wilcox <willy@debian.org>
Date: Sat, 30 Aug 2003 02:08:41 +0000
Subject: Re: [PATCH] efivars update
Message-Id: <marc-linux-ia64-106220934727031@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106219352715985@msgid-missing>
In-Reply-To: <marc-linux-ia64-106219352715985@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Aug 29, 2003 at 02:59:43PM -0700, Patrick Mochel wrote:
> That patch is below. I'll be sending it to Linus once he gets back from
> vacation, unless anyone has any serious objections to it. Note that it
> completely removes any limitation on the length of a kobject (and sysfs
> directory) name.

Why keep another copy of the name?  Why not use kobj->dentry->qstr->name?
I thoroughly approve of kobject_name() though -- hide the implementation.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
