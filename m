From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Fri, 04 May 2001 15:09:37 +0000
Subject: Re: [Linux-ia64] HP Simulator & Kernel 2.4.3
Message-Id: <marc-linux-ia64-105590693005537@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005529@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005529@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> On Thu, May 03, 2001 at 02:37:53PM -0300, Gustavo Niemeyer wrote:
> > Hello!
> > 
> > I'm trying to make the hp simulator work with kernel 2.4.3. Is
> > that possible, or the simulator has been left out for a long time?
> 
> I assume you are talking about version 0.873l3. This one should still work.
> In fact, I did the test with this exact same version of the simulator 
> and 2.4.3 + 010405 patch from David and it works just fine. I have attached
> the config file I used.
[...]

Thank you Stephane!!

With your config file I'm able to boot.

> Hope this helps.

Helped, indeed! ;-)

Just a note: there's a little typo in bootloader.c, at line 91. The
word volatile is being written as "volatiVe".

Thanks again!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

