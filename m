From: Perry Wagle <wagle@wirex.com>
Date: Wed, 15 Jan 2003 17:43:39 +0000
Subject: [Linux-ia64] Distributions using gcc 3.2 or later
Message-Id: <marc-linux-ia64-105590709805681@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi --

I need to test and improve modifications of GCC 3.2 or later on a IA64 
as part of a demonstration that those modifications aren't IA32 
specific.  As it is, I am just now showing that I can build entire 
production quality Linux distributions with my (currently non-standard) 
compilers on IA32, and I want to extend that to a couple more platforms.

Intel has graciously short-term-loaned me a IA64.  Before Christmas 
break, I poked around, and all the Linux distributions for IA64 seemed 
GCC 2.96 based, except for the Redhat rawhide distribution.  But, 
testing with alpha-test distributions makes me nervous that I would be 
testing much more than my changes.  Now that my compiler modification 
is starting to work, I thought I'd poke my head out and ask what 
distribution I should use that would expect GCC 3.2 or later?

Or perhaps, if you have a fork going in GCC for IA64, I should use it 
instead?  The purpose is to propose inclusion of my modifications into 
the GCC main branch.

-- Perry Wagle (wagle@wirex.com)


