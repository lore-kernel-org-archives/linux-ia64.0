From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Nov 2002 16:58:33 +0000
Subject: Re: [Linux-ia64] One little, two little, three little endian...
Message-Id: <marc-linux-ia64-105590709805454@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805439@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805439@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 15 Nov 2002 10:11:56 -0600, Mario Smarduch <cms063@email.mot.com> said:

  Mario> David a quick question. Even though the library problem is
  Mario> overcomed, how would signal handling be accomplished by an
  Mario> application running in big-endian. Doesn't the kernel fill in
  Mario> the siginfo and context while runing in little endian?

Yes, signal-handling would have to be adjusted, just like we do for an
x86 process (the signal stack format is somewhat different for hp-ux
at any rate, so it's more than just endianness).

	--david

