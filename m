From: Keith Owens <kaos@sgi.com>
Date: Mon, 20 Jan 2003 11:05:46 +0000
Subject: Re: [Linux-ia64] Re: realtime signals not held
Message-Id: <marc-linux-ia64-105590709805731@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805730@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805730@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 20 Jan 2003 21:10:28 +1100, 
Keith Owens <kaos@sgi.com> wrote:
># gcc kao2.c -o kao2
># ./kao2

ps.  Run the test case from the command line, not from inside an
editor.  vi blocks RTMIN itself (?), which masked the problem and made
for some interesting problem isolation.


