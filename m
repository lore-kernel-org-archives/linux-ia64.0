From: Matthew Wilcox <willy@debian.org>
Date: Fri, 08 Nov 2002 17:52:19 +0000
Subject: Re: [Linux-ia64] reader-writer livelock problem
Message-Id: <marc-linux-ia64-105590709805365@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805355@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805355@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Nov 08, 2002 at 11:41:57AM -0600, Van Maren, Kevin wrote:
> processor to acquire/release the lock once.  So with 32 processors
> contending for the lock, at 1us per cache-cache transfer (picked

if you have 32 processors contending for the same spinlock, you have
bigger problems.

-- 
Revolutions do not require corporate support.

