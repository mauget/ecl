#                                G E N I N C
#                 I B M   I N T E R N E L   U S E   O N L Y
#
# A very specialized ad-hoc TURBO PASCAL => AVPAS51 translator. Tailored for
# a subset of TURBO PASCAL as used by Randy Ray in the REMS project.
#
# Creates prog.INC from prog.pas
#
#       Louis E. Mauget 09/27/89       MODIFIED by Clayton Sims 10/03/89

BEGIN   {
        print "Initializing external function table"
        FS = " "

        # build table from args passed on the command line  # ADDED 10/03/89
        for (i=2; i<ARGC; i++)  {
            BuildTable(candidates,ARGV[i]);
          }

        # null out args on command line so awk won't process them too
        for(j=2;j<ARGC;j++) {                                # ADDED 10/03/89
            ARGV[j]=""
          }

}


END     {
    print "Outputting " headerfile
    DisplayArray(externs, headerfile)
}


# Match first record. FILENAME now set, so gen some names based on it.
FNR == 1 {
        FILENAME = toupper(FILENAME)

        headerfile = FILENAME                   # Build headerfile name
        sub(/\.[a-zA-Z0-9\$_#@]+$/, ".H" ,headerfile)  # CHGED 10/03/89
}


# Main processing routine
{
    CacheXcludes($0)         # ADDED 10/03/89 CBS
    CacheExternalName($0)    # Save external names we encounter

}

# Place external names in a set
function CacheExternalName(buffer) {
# if(toupper($1) != "PROCEDURE"  &&  toupper($1) != "FUNCTION")   {
  if(toupper($1) != "FUNCTION") {
    if(toupper($1) != "PROCEDURE") {
      buffer = StripComments(buffer)
      buffer = StripStrings(buffer)
      while (match(buffer,/[a-zA-Z][_a-zA-Z0-9]*/) ) {
          procn = toupper(substr(buffer, RSTART, RLENGTH))
          if (procn in candidates)              {  # Is it external name?
            if (!(procn in externs)) {  # And not seen before?
              if (!(procn in xcludes)) { # ADDED 10/03/89
                externs[procn] = candidates[procn]; # Remember it
              }
            }
          }
          buffer = substr(buffer, RSTART+RLENGTH)   # Rest of string
      }
    }
  }
}
function CacheXcludes(buffer) {        # ADDED FUNCTION 10/03/89
  if(match(toupper($1),/(FUNCTION)|(PROCEDURE)/)){
    if (!(match(buffer,/EXTERNAL/))){
      gsub(/:/, " ", $0)
      buffer = StripComments(buffer)
      buffer = StripStrings(buffer)
      while (match(buffer,/[a-zA-Z][_a-zA-Z0-9]*/) ) {
          procn = toupper(substr(buffer, RSTART, RLENGTH))
          if (procn in candidates)              {  # Is it external name?
            if (!(procn in xcludes))    # And not seen before?
              xcludes[procn] = candidates[procn]; # Remember it
          }
          buffer = substr(buffer, RSTART+RLENGTH)   # Rest of string
      }
    }
  }
}


# Build table of proc/func prototypes from proclib
# Called by BEGIN
function BuildTable(table, proclib, name)   {
        while (getline < proclib ) {
            if (match(toupper($1), /(FUNCTION)|(PROCEDURE)/ ))
                if ((name = ExtractProcName($2)) != "")
                    table[name] = $0
        }
        return table
}

# Given a field, extract assumed proc/func name from position 1
function ExtractProcName(field, procn )  {

        if (match($2, /^[a-zA-Z][_a-zA-Z0-9]*/) )   # Isolate proc/func name
            procn = toupper(substr(field, RSTART, RLENGTH)) # Extract proc/func
        else
            procn = ""
        return procn
}


# Dump an array to the screen
function DisplayArray(array, file, s) {

    print "{*---------------------------*}" >file
    print "{* External Declares         *}" >file
    print "{*---------------------------*}" >file
    for (s in array) {
      # print s ":"
        print array[s]  >file
    }
}


# Return buffer stripped of comments (intended for work buffers)
function StripComments(buffer) {
    gsub(/{.*}/, "", buffer)
    return buffer
}

# Return buffer stripped of strings (intended for work buffers)
function StripStrings(buffer) {
    gsub(/'.*'/, "", buffer)
    return buffer
}

# Strip comments and strings (intended for work buffers)
function Strip(buffer) {
    return StripStrings(StripComments(buffer))
}
