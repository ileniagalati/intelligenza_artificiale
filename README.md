# intelligenza_artificiale


Comando per l'esecuzione:


/path/to/java_executable \
-javaagent:/path/to/IntelliJ_IDEA/Contents/lib/idea_rt.jar=PORT:/path/to/IntelliJ_IDEA/Contents/bin \
-Dfile.encoding=UTF-8 \
-Dsun.stdout.encoding=UTF-8 \
-Dsun.stderr.encoding=UTF-8 \
-classpath /path/to/project/output:/path/to/project/lib/pddl4j-4.0.0.jar \
package.classname \
/path/to/domain_file.pddl \
/path/to/problem_file.pddl \
-e HEURISTIC -t TIME_LIMIT -w WEIGHT -sp STOCASTIC_PRUNING_FLAG
