From: Matthew Wilcox <willy@debian.org>
Date: Fri, 30 May 2003 11:56:30 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706085@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 29, 2003 at 04:33:49PM -0700, Luck, Tony wrote:
> Seems odd that we read "cpu 5 cpe" from the "control" file, and then
> turn around to write the same thing back to the same file.

Agreed.

> Applications block reading the "event" file (or use poll(2) on it) to
> find out that it is worth reading.  When they read, they see the "cpu
> 5 cpe" type message.  They write that to "control", and then read from
> "data".
> 
> Or, back to two files: {event,data} ... we read from "event" to see
> what happened.  Writing to "data" controls what will be read from "data".

I like this alternative better.  But there's a bit of a race condition if
two programs are attempting to use these files at the same time.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk

