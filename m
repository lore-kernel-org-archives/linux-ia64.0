From: Dragan Stancevic <visitor@valinux.com>
Date: Fri, 16 Feb 2001 06:10:58 +0000
Subject: Re: [Linux-ia64] 2.4.1 network problems
Message-Id: <marc-linux-ia64-105590693005156@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005146@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005146@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 14, 2001, David Mosberger <davidm@hpl.hp.com> wrote:
; >>>>> On Wed, 14 Feb 2001 12:10:24 -0800, Michael Madore <mmadore@turbolinux.com> said:
; 
;   Mike> In addition to the >1024MB problem, I am also experiencing a
;   Mike> reproducible nfs hang on Lions.  If I copy this file
; 
;   Mike>    ftp://frontier.turbolinux.com/pub/ia64/nfshang.bin
; 
;   Mike> from an nfs server to the local file system, the copy hangs
;   Mike> after transferring 294912 bytes.  If I copy the file from the
;   Mike> local filesystem to the server, the copy completes
;   Mike> successfully.  The hang only occurs with certain files.
; 
; That's a rather bizarre bug.  I can confirm this is happening on one
; of our Lions as well.  The Big Sur (also with eepro100) is fine
; though.  The Lion has 4GB and the Big Sur only 1GB of RAM.

If I am right it's not the offset but it's rather the data combined with
a certain fragmentation of the packets, if you use these two files
to "cp" them over nfs you should see the hang at 0 bytes transfered,
don't know yet why not all systems are affected, I am still working on it.

ftp://ftp.valinux.com/pub/people/visitor/0xdeadbeef/

-- 
No Kernel Hackers were harmed during writing of this email.

                                                -Dragan

