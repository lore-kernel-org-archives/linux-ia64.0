From: Ben Woodard <woodard@redhat.com>
Date: Wed, 04 Feb 2004 02:45:58 +0000
Subject: Re: [patch] 0/5 2.4.25-pre7 mca.c cleanup
Message-Id: <1075862758.11543.130.camel@xenophanes>
List-Id: <linux-ia64.vger.kernel.org>
References: <6503.1075705201@kao2.melbourne.sgi.com>
In-Reply-To: <6503.1075705201@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2004-02-03 at 17:19, Ben Woodard wrote:
> The changes in salinfo_decode.c fix a problem where the salinfo_decode
> daemon crashes when it receives the second error since stdout and stderr
> are already closed causing the freopen to fail.
> 

Oops I forgot to explain why this is important. With this bug in the
salinfo_decode, the daemon exits when it tries to open the decoded file
for the 2nd cpe it receives. Thus the computer stays up since the
salinfo_decode  daemon is not running.

Since we know that the daemon has already seen the event, fetched the
data, and written the raw version of the error. The only interaction
that it has with the salinfo /proc file system code is the handling of
the write to clear the error. This is leading me to believe that the
race is between the salinfo write routine and the cpe handler over in
mca.c. I just haven't spotted the problem yet. (though I could be blind
or off target.)

-ben

