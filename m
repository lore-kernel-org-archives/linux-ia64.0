From: Matthew Wilcox <willy@debian.org>
Date: Mon, 29 Jul 2002 20:46:56 +0000
Subject: Re: [Linux-ia64] Linux kernel deadlock caused by spinlock bug
Message-Id: <marc-linux-ia64-105590701905844@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905843@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905843@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Jul 29, 2002 at 03:37:17PM -0500, Van Maren, Kevin wrote:
> I changed the code to allow the writer bit to remain set even if
> there is a reader.  By only allowing a single processor to set
> the writer bit, I don't have to worry about pending writers starving
> out readers.  The potential writer that was able to set the writer bit
> gains ownership of the lock when the current readers finish.  Since
> the retry for read_lock does not keep trying to increment the reader
> count, there are no other required changes.

however, this is broken.  linux relies on being able to do

read_lock(x);
func()
  -> func()
       -> func()
            -> read_lock(x);

if a writer comes between those two read locks, you're toast.

i suspect the right answer for the contention you're seeing is an improved
get_timeofday which is lockless.

-- 
Revolutions do not require corporate support.

