From: Eric Piel <Eric.Piel@Bull.Net>
Date: Fri, 28 Feb 2003 09:52:33 +0000
Subject: [Linux-ia64] Port of the posix timers to IA64
Message-Id: <marc-linux-ia64-105590709805943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello David,

I'm working on the port of the posix timers to IA64. The first (over 4)
part has just been integrated in the linus tree (2.5.63) so I think you
can find interest in my work. 
Even if it's supposed to be portable accross platforms, due to some mix
between long and int, it doesn't run correctly on IA64. 

Here comes my question, I'm still newbie to kernel hacking and IA64
compilation and I don't know how I should handle some troubles with
longs. In the code I have some cases like this one:

long v;
:
:
if ( v >= (1 << 56)){
:
}

It seems very strange for me that when compiling this part gcc considers
that eveything must be converted to int. I have to write 1UL instead of
1 in order to obtain the correct behaviour of the code. I guess you've
already come along with such problem.
So, first, do you think it's a bug in gcc? Second should I convert every
1's I see by 1UL's (there are only few but sounds so strange)?

Thanks
Eric

