From: Jack Steiner <steiner@sgi.com>
Date: Wed, 09 May 2001 13:38:42 +0000
Subject: Re: [Linux-ia64] kernel update (relative to 2.4.4)
Message-Id: <marc-linux-ia64-105590693005557@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> BIG CAVEAT: even though the kernel currently is syncing the cycle
>> counters, application code MUST NOT rely on this.  Instead, if an
>> application needs fine-grained and light-weight timestamps, it should
>> use the POSIX *clock* routines that Uli added recently to libc.  I can
>> almost guarantee you that future machines will NOT have synchronized
>> clocks (and we'll also want to support systems where different CPUs
>> have different clock speeds) and because of this, the *clock* routines
>> and gettimeofday() are the recommended and RELIABLE way for obtaining
>> fine-grained timestamps.

FYI, The IA64 system being built by SGI has multiple nodes. The clocks on
different nodes are not synchronized.

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


