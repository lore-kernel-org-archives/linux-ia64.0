From: Francis Galiegue <fg@mandrakesoft.com>
Date: Thu, 11 Jan 2001 16:00:19 +0000
Subject: Re: [Linux-ia64] netfilter doesn't compile...
Message-Id: <marc-linux-ia64-105590693005023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005022@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005022@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 11 Jan 2001 hill_ken@emc.com wrote:

> 
> I just tried to build a kernel with netfilter setup as a module. No Go. Is
> this new news? I can provide more details if it is.
> 

No, it's not news. The config files in 2.4 are a little screwy as they would
allow netfilter support to be compiled as a module but NAT support compiled
in...

Either put the whole stuff as built in or as modules, this should do the trick
until all this stuff is sorted out.

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


