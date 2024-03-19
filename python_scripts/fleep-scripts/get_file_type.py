import argparse
import fleep

def get_file_type(filename):

    """
    This function takes a filename as input, opens the file in binary mode,
    gets the file type, extension, and MIME type using the fleep library,
    and prints these details. It then closes the file.

    Parameters:
    filename (str): The name of the file to get info from

    Returns:
    None
    """

    file = open(filename, "rb")
    info = fleep.get(file.read(128))
    print('Type: ' + str(info.type))            # prints ['raster-image']
    print('Extension: ' + str(info.extension))  # prints ['png']
    print('MIME: ' + str(info.mime))            # prints ['image/png']

    file.close()

def main():
    parser = argparse.ArgumentParser(description='Get file extension')
    parser.add_argument('FileName', metavar='filename', type=str, help='the file to get info from')
    args = parser.parse_args()
    get_file_type(args.FileName)

if __name__ == "__main__":
    main()