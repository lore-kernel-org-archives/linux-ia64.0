From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Sat, 15 Nov 2003 06:20:48 +0000
Subject: Re: making unwcheck.sh
Message-Id: <marc-linux-ia64-106887730709091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106883536806062@msgid-missing>
In-Reply-To: <marc-linux-ia64-106883536806062@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

What's wrong with Perl? :)  Okay, so there's plenty wrong with Perl, but
I think it's a decent tool for the job.

I wrote a quick Perl version, though it only works properly on 64-bit
platforms (reports an integer overflow otherwise).  It wouldn't be too
hard to work around this if it's an issue (since for a given function
the upper 32 bits should presumably be invariant), in fact the same
workaround could probably be done in the awk script.

http://www.cse.unsw.edu.au/~matthewc/files/unwcheck.pl

Python seems to handle big numbers better but I don't really know enough
Python.

Matt


On Fri, Nov 14, 2003 at 10:38:39AM -0800, David Mosberger wrote:
> Is anybody willing/capable/interested in fixing unwcheck.sh so it can
> actually handle 64-bit addresses?  I'm not much of an awk hacker but I
> noticed that the only reason the script works on the kernel is because
> it drops the first digit of each address (look for gsub() to see what
> I mean).  Of course, that makes it work on the kernel, but it won't
> work for checking a shared object, for example.  Perhaps the whole
> script should just be converted to a real[1] language?
> 
> 
> 	--david
> 
> [1] real = anything other than awk, perl, or tcl... ;-)
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
