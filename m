From: "David S. Miller" <davem@redhat.com>
Date: Tue, 23 Sep 2003 17:57:12 +0000
Subject: Re: NS83820 2.6.0-test5 driver seems unstable on IA64
Message-Id: <marc-linux-ia64-106434071405313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106394503001622@msgid-missing>
In-Reply-To: <marc-linux-ia64-106394503001622@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Sep 2003 12:58:59 -0500
"Van Maren, Kevin" <kevin.vanmaren@unisys.com> wrote:

> Rate-limited unaligned loads in user space make a lot more sense, since
> they _may_ point out issues in the code.

That's what generates the bulk of the noise in people's ia64
dmesg output.
