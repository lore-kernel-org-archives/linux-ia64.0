From: Keith Owens <kaos@sgi.com>
Date: Wed, 12 Jan 2005 20:46:24 +0000
Subject: Re: new utility for decoding salinfo records
Message-Id: <30808.1105562784@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1105458388.22104.7.camel@quince.llnl.gov>
In-Reply-To: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 12 Jan 2005 08:57:36 -0800, 
Ben Woodard <woodard@redhat.com> wrote:
>Keith, 
>
>I beg to differ with you it is obvious from your post that you didn't
>even look at what I sent. You were so spring loaded with your attack on
>salinfod (something that I did not send along) that you failed to
>actually look at what I produced. In my opinion, that is somewhat
>unprofessional.

The patch you sent to the list adds salinfo_daemon.C, containing this line

+  strm << "salinfod version " << VERSION

If you include salinfod in your patch then of course I am going to
fight it.

>salinfo_decode2 is a completely offline record processor. It does not
>interfere with the read, decode, clear cycle. salinfo_decode2 simply
>looks at the records that are left by the salinfo_decode2 daemon in raw directory.
                                           ^^^^^^^^^^^^^^^
I am going to give you the benefit of the doubt and assume that you meant
salinfo_decode there, not your attempted replacement.

If salinfo_decode2 is completely offline then make it a separate
package called salinfo_summary instead of trying to add it to
salinfo_decode.  The existing salinfo_decode is vendor neutral and it
is going to stay that way.  Different vendors and/or distributions have
their own requirements for tracking problems, they can choose to use
salinfo_summary or they can ignore it and use their own tracking
system.  When you lump the summary program in with the decode program
then you take away the ability for anybody to determine how they
summarize the SAL records.

>If you had actually looked at what I sent, you would have seen that
>there is absolutely no existing salinfo_decode functionality removed.

I did look, salinfo_daemon.C is in the patch that you sent and it
removes the existing salinfo_decode functionality.

Remove salinfo_daemon.C, make the summary code a separate package from
salinfo_decode and I might believe that you are not trying to break
salinfo_decode.  Given the salinfo mess in RHEL4 beta, I am extremely
suspicious of your current approach.

