From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Oct 2003 22:19:49 +0000
Subject: RE: [RFC] prevent "dd if=/dev/mem" crash
Message-Id: <marc-linux-ia64-106642941215349@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106642876514553@msgid-missing>
In-Reply-To: <marc-linux-ia64-106642876514553@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I expect there are probably different opinions about the idea
> that "dd if=/dev/mem" exits without doing anything.  Sparc and
> 68K have nearby code that bit-buckets writes and returns zeroes
> for reads of page zero.  We could do that, too, but it seems like
> kind of a hack, and holes on ia64 can be BIG (on the order of
> 256GB for one box).

Filling in the holes does seem like a bad idea, but so does returning
EOF when you hit a hole (which is what I think your patch is doing).

Would ENODEV be better?

-Tony
