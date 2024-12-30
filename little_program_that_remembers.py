"""please `pip install thefuzz python-levenshtein`
"""
#!/usr/bin/python3
import json
import logging
import os

from thefuzz import process


class Program():
    """ I created this in about four hours total, scratching an itch I've had for a while.
    It's a simple question-answering program, which I can feed answers into for questions it hasn't seen already.
    It uses thefuzz for fuzzy matching questions, and has some rudimentary debugging build into it.
    TODOs:
        - try and extend this to use SQLite or any other SQL DB as a memory backend
        - add metadata for questions and answers
        - allow answers to be modified from the command line ✅
        - allow questions to be deleted from the command line ✅
        - make it accept cli args and output an answer, letting me pipe its output to another program
    """
    def __init__(self) -> None:
        self.memfile_name = "memfile.json"
        self.memory_map = {}
        self._program_load_memory_map()
        self.debug_commands = ("DEBUG", "INTROSPECT", "VIEW_MEMORY", "CUSTOM", "DELETE_QUESTION")

    def _program_debug_view_memory(self):
        print(json.dumps(self.memory_map, indent=4))

    def _program_debug_main(self):
        print("Now debugging")
        command_index = "".join([f"\n{i}. {self.debug_commands[i]}" for i in range(len(self.debug_commands))])
        while True:
            print("What would you like to do?")
            print(command_index)
            print("9. Exit Debugging")
            try:
                command = input()
                if command.isnumeric():
                    command = int(command)
                    if 0 < command < len(self.debug_commands):
                        command_name = self.debug_commands[command].lower()
                    elif command == 9:
                        print("Exiting Debugging")
                        break
                    else:
                        print("Invalid input. Try again?")
                        continue
                else:
                    command_name = command
                if command_name.upper() not in self.debug_commands:
                    print("Bad value. Try again.")
                    continue
                else:
                    eval(f"self._program_debug_{command_name.lower()}()")
            except Exception as exc:
                print("Couldn't run debug command, sorry.")
                logging.exception(exc)

    def _program_debug_custom(self):
        try:
            command_str = input("What code d'you wanna run? One-liners only for now, please\n")
            eval(command_str)
        except Exception as exc:
            print("Couldn't run custom code, sorry. reason:")
            print(exc)

    def _program_debug_introspect(self):
        # I am aware I could have used the inspect module for this, but maybe
        # I'll try it in a later pass
        # print(dir(self))
        implemented_methods_list = [i for i in dir(self) if str(i)[:8] == "_program"]
        print("Methods implemented are: {}".format(str(implemented_methods_list)))

    def _program_load_memory_map(self):
        if not os.path.exists(self.memfile_name):
            with open(self.memfile_name, 'x'):
                print("Creating new memoryfile")
            memory_map = {}
        else:
            with open(self.memfile_name, "r") as memoryfile:
                memory_map = json.load(memoryfile)
        self.memory_map = memory_map

    def _program_debug_delete_question(self):
        question_index = [i for i in self.memory_map.keys()]
        for i in range(len(question_index)):
            print(i, ": ", question_index[i])
        qn_index = input(
            "Enter the question index you want to delete, or [n] to exit:\n\t; "
        )
        if qn_index == "n":
            pass
        elif qn_index.isdigit() and \
            int(qn_index) in range(len(question_index)):
            self.memory_map.pop(question_index[int(qn_index)])
        else:
            print("Invalid input!")

    def _program_run_check_loop(self):
        memory_map = self.memory_map
        try:
            while True:
                try:
                    data = input("> Ask me a question:\n\t; ")
                except Exception as exc:
                    print("Not sure that was correct. Try again?")
                    continue
                pass

                if data == "DEBUG":
                    self._program_debug_main()
                    continue

                try:
                    fl_sure = 0
                    answer = None
                    answer_ranker = process.extractOne(data, memory_map.keys())

                    if answer_ranker and answer_ranker[1] >= 85:
                        # print(answer_ranker)
                        if answer_ranker[1] > 95:
                            print("> I know the answer! It is:")
                            fl_sure = 1
                        else:
                            print("\tI'm not sure. Is it:")
                        answer = memory_map[answer_ranker[0]]
                        print("\t", answer)

                    if not answer or not fl_sure:
                        print("Can you tell me the answer? (enter [n] to skip)")
                        answer = input("Answer: ")
                        if answer == "n":
                            print("Skipping...")
                        else:
                            print("Adding it to memory!")
                            memory_map[data] = answer
                    else:
                        fl_check_answer_update = input("Would you like to update this answer? [Y/n]\n\t;")
                        if fl_check_answer_update == "n":
                            print("Skipping...")
                        else:
                            updated_answer = input("Answer: \n; ")
                            memory_map[data] = updated_answer
                except Exception as exc:
                    print(exc)
                    print("Seems like something broke. Sorry about that. Try again?")
                    continue
        finally:
            if len(memory_map):
                json.dump(memory_map, open(self.memfile_name, "w"), indent=4)
            print("\nHandling termination, writing memory to file")
            return

    def start(self):
        self._program_run_check_loop()

if __name__ == "__main__":
    program_instance = Program()
    program_instance.start()
