From: Randolph Chung <randolph@tausq.org>
Date: Fri, 21 Feb 2003 07:13:35 +0000
Subject: Re: [Linux-ia64] ski and gcc-3.x
Message-Id: <marc-linux-ia64-105590709805896@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805894@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805894@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> That's only a warning though, right?  It should be harmless.

no, ski segfaults right after that.

I recompiled 2.5.60 without -g and it loads, but when i run it, it says:
* run
Unable to create console window
21 insts (0 faults), 0.01 sec, 4086 i/s

(i'm running this remotely, so no X ...)

> In any case: I currently have v0.9.81l1 of Ski in alpha testing and
> beta testing should start next week.  If you can wait till then, that
> would be easiest.  Otherwise, let me know and I'll see about sending
> you the current test-binary.

ok, this can wait :)

thanks,
randolph
-- 
Randolph Chung
Debian GNU/Linux Developer, hppa/ia64 ports
http://www.tausq.org/

