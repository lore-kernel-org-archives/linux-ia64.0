From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 18 Nov 2004 06:42:36 +0000
Subject: HP Caliper available for Linux/ia64
Message-Id: <20041118064235.GA22420@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To Everyone,

I am happy to report that Caliper for Linux/ia64 is now available as
a free download Beta. Read the following annoucement. It works only
with 2.6.x (x > 5 but preferrably 2.6.9)  kernels. Caliper exploits
the perfmon2 interface, therefore your kernel must have CONFIG_PERFMON
turned on (which is the default).

Caliper is a very powerful yet fairly easy to use monitoring tool which
can be used to collect profiles or simple counts. When sampling it shows
fully correlated assembly-level profiles. To collect a simple flat profile
in a text file (here fp.out):

	caliper fprof -o fp.out my_test_program

Enjoy,

------------------------------------------------------------------------------
From: Caliper Team

Apologies if you receive notice of this multiple times.

We would like to announce the start of an external beta program for the HP
Caliper performance tool on Linux for Itanium.

HP Caliper is a general purpose performance tool for applications on
Itanium-based systems (see www.hp.com/go/caliper for an overview).  HP
Caliper has been available on HP-UX for several years, and is now being made
available as a beta release on Linux/Itanium systems.

We are looking for interested users to help validate the effectiveness and
quality of HP Caliper for Linux.

If you are interested in trying this new HP Caliper for Linux, thanks very
much!  But first, here are some known limitations and restrictions that you
need to read:

   1. HP Caliper for Linux will only run on a Linux kernel with version
      2.6.5 or higher.  Note that the current release of RedHat Linux (RH3)
      is based on a 2.4 Linux kernel, on which Caliper _will not_ run.

      (HP Caliper has been successfully, though not thoroughly, tested on
      beta releases of RedHat4, though there are some minor limitations on
      such systems.)

      The latest SUSE server Linux release (SLES9) _is_ based on a 2.6.x
      Linux kernel, and so Caliper will run on such systems just fine.

   2. HP Caliper requires the following minimum library versions:
   
         * glibc:     2.3.3
         * libstdc++: 3.3.3
         * libgcc:    3.3.3

   3. The functionality of HP Caliper for Linux is a subset of Caliper on
      HP-UX.  If you're familiar with Caliper on HP-UX, here is a list of
      HP-UX Caliper features that are NOT currently available on Linux:

      * The following configuration files are not shipped with HP Caliper
        for Linux/Itanium:

          * pbo
          * func_count
          * func_cover
          * arc_count
          * cgprof
          * cpu_metrics

      * The following options are not supported on Linux:

          * --call-types 
          * --pbo-data-type
          * --flow-data
          * --flow-log
          * --scope=kernel
          * --memory-usage
          * --user-regions

      * Auto-invocation of HP Caliper by running a binary is not supported
        (requires HP-UX loader functionality).  This includes the following
        unsupported --process arguments:

          * autoinvoke
          * autoinvoke-forks


What we would like from you:

   - Register for and download HP Caliper for Linux/Itanium
   - Provide feedback to us, as early and as often as you can, on

         + install problems
         + incorrect output
         + confusing documentation
         + abnormal operation

   - Provide final feedback to us by the end date of the beta program (TBD).

What we'll do for you:

   - Provide the initial version of HP Caliper for Linux, for you to use and
     abuse
   - Provide fast responses to problems, crashes, etc.
   - Update the current beta version regularly, with all fixes incorporated

If you are interested in helping us by becoming a beta tester for Caliper on
Linux, simply point your browser to

        http://www.hp.com/go/caliper

and follow the directions to register for, and download, HP Caliper for
Linux.

Thanks very much!

-- 

-Stephane
